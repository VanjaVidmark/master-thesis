import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.absoluteOffset
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.isActive
import kmp_benchmarks.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.toSize
import kotlinx.datetime.Clock
import org.example.kmpbenchmarks.animations.AnimationsController
import org.jetbrains.compose.resources.DrawableResource
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.floor

data class AnimatedStar(
    val image: DrawableResource,
    val speed: Float,
    val yOffset: Float,
    val phaseOffset: Float,
    val direction: Float,
    val rotationSpeed: Float
)

@Composable
fun AnimationsScreen(onDone: () -> Unit) {
    val isAnimating by AnimationsController.isAnimating.collectAsState()
    var containerSize by remember { mutableStateOf(IntSize.Zero) }
    val imageResources = listOf(
        Res.drawable.star1, Res.drawable.star2, Res.drawable.star3,
        Res.drawable.star4, Res.drawable.star5, Res.drawable.star6,
        Res.drawable.star7, Res.drawable.star8, Res.drawable.star9, Res.drawable.star10
    )

    val stars = remember {
        List(100) {
            AnimatedStar(
                image = imageResources.random(),
                speed = (20..300).random().toFloat(),
                yOffset = (100..1500).random().toFloat(), // overridden when containerSize is known
                phaseOffset = (0..1000).random().toFloat(),
                direction = if ((0..1).random() == 0) 1f else -1f,
                rotationSpeed = (30..180).random().toFloat()
            )
        }
    }

    // Animation state
    var currentTime by remember { mutableStateOf(0L) }

    LaunchedEffect(isAnimating) {
        if (!isAnimating) {
            onDone()
        } else {
            val startTime = Clock.System.now()
            while (isActive) {
                currentTime = Clock.System.now().minus(startTime).inWholeMilliseconds
                kotlinx.coroutines.delay(16) // ~60fps
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .onGloballyPositioned { containerSize = it.size }
    ) {
        if (isAnimating && containerSize.width > 0) {
            val totalWidth = containerSize.width + 200f

            stars.forEachIndexed { _, star ->
                val timeSec = currentTime / 1000f
                val basePos = timeSec * star.speed * star.direction + star.phaseOffset
                val x = (basePos + totalWidth) % totalWidth - 100f
                val y = star.yOffset % containerSize.height.toFloat()
                val angle = timeSec * star.rotationSpeed * star.direction

                Image(
                    painter = painterResource(star.image),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .rotate(angle)
                        .absoluteOffset { IntOffset(x.toInt(), y.toInt()) }
                )
            }
        }
    }
}

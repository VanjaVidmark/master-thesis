import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.absoluteOffset
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import kotlinx.coroutines.isActive
import kmp_benchmarks.composeapp.generated.resources.*
import org.jetbrains.compose.resources.painterResource
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import kotlinx.datetime.Clock
import org.example.kmpbenchmarks.animations.AnimationsController
import org.jetbrains.compose.resources.DrawableResource
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

data class AnimatedStar(
    val image: DrawableResource,
    val x: Float,
    val y: Float,
    val scaleOffset: Float,
    val visibilityOffset: Float
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
        List(250) {
            AnimatedStar(
                image = imageResources.random(),
                x = Random.nextFloat() * 1080f,
                y = Random.nextFloat() * 2340f,
                scaleOffset = Random.nextFloat() * 1000f,
                visibilityOffset = Random.nextFloat() * 1000f
            )
        }
    }

    var currentTime by remember { mutableStateOf(0L) }

    LaunchedEffect(isAnimating) {
        if (!isAnimating) {
            onDone()
        } else {
            val startTime = Clock.System.now()
            while (isActive) {
                currentTime = Clock.System.now().minus(startTime).inWholeMilliseconds
                kotlinx.coroutines.delay(16) // ~60 FPS
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .onGloballyPositioned { containerSize = it.size }
    ) {
        if (isAnimating && containerSize.width > 0) {
            stars.forEach { star ->
                val timeSec = currentTime / 1000f

                val scale = 0.8f + 0.4f * sin((timeSec + star.scaleOffset / 1000f) * 2 * PI).toFloat()
                val alpha = 0.5f + 0.5f * sin((timeSec + star.visibilityOffset / 1000f) * 2 * PI).toFloat()

                Image(
                    painter = painterResource(star.image),
                    contentDescription = null,
                    contentScale = ContentScale.Fit,
                    modifier = Modifier
                        .absoluteOffset { IntOffset(star.x.toInt(), star.y.toInt()) }
                        .alpha(alpha)
                        .graphicsLayer {
                            scaleX = scale
                            scaleY = scale
                        }
                )
            }
        }
    }
}

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.IntSize
import kotlin.random.Random
import org.jetbrains.compose.resources.painterResource
import org.jetbrains.compose.resources.DrawableResource
import kmp_benchmarks.composeapp.generated.resources.*
import org.example.kmpbenchmarks.animations.AnimationsController

data class AnimatedStar(
    val image: DrawableResource,
    val x: Float,
    val y: Float
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
        List(200) {
            AnimatedStar(
                image = imageResources.random(),
                x = Random.nextFloat() * 1080f,
                y = Random.nextFloat() * 2340f
            )
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .onGloballyPositioned { containerSize = it.size }
    ) {
        if (isAnimating && containerSize.width > 0) {
            stars.forEach { star ->
                AnimatedStarView(star = star)
            }
        }
    }

    LaunchedEffect(isAnimating) {
        if (!isAnimating) {
            onDone()
        }
    }
}

@Composable
fun AnimatedStarView(star: AnimatedStar) {
    val infiniteTransition = rememberInfiniteTransition(label = "star-${star.hashCode()}")

    val alpha by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 500, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse,
            initialStartOffset = StartOffset(Random.nextInt(0, 1000))
        ),
        label = "alpha"
    )

    val scale by infiniteTransition.animateFloat(
        initialValue = 0.7f,
        targetValue = 1.3f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 500),
            repeatMode = RepeatMode.Reverse,
            initialStartOffset = StartOffset(Random.nextInt(0, 1000))
        ),
        label = "scale"
    )

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

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][1/4] b44: Ignore carrier lost errors
Date: Fri, 17 Sep 2004 11:54:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414B08C7.3050505@pobox.com>
References: <200408292218.00756.jolt@tuxbox.org> <200408292233.03879.jolt@tuxbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Pietikainen <pp@ee.oulu.fi>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Schirmer <jolt@tuxbox.org>
In-Reply-To: <200408292233.03879.jolt@tuxbox.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Florian Schirmer wrote:
> Hi,
> 
> some (?) hardware seems to be buggy and is reporting bogus carrier lost 
> values. Both reference implementations from Broadcom indicate that this 
> counter is not reliable and therefore ignore it. We should do the same. 
> "Fixes" the carrier lost problem i've seen.
> 
> Regards,
>   Florian
> 
> Signed-off-by: Florian Schirmer <jolt@tuxbox.org>

patch applied to 2.6.x

From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.12-rc6] 3c59x: remove superfluous vortex_debug test
 from boomerang_start_xmit
Date: Sun, 12 Jun 2005 23:31:24 -0400
Message-ID: <42ACFE0C.1080604__18341.3132014268$1118633436$gmane$org@pobox.com>
References: <20050610142702.GC10449@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20050610142702.GC10449@tuxdriver.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Remove the superfluous test of "if (vortex_debug > 3)" inside the
> "if (vortex_debug > 6)" clause early in boomerang_start_xmit.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

ACK (I presume akpm will send this one upstream)

From: Steve Hill <steve@services.navaho.net>
Subject: Re: IPSEC
Date: Wed, 9 Mar 2005 17:01:46 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0503091700030.18067@sorbus2.navaho>
References: <Pine.LNX.4.61.0503081706560.11525@sorbus2.navaho>
 <422DE487.5020800@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <422DE487.5020800@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005, Patrick McHardy wrote:

> This is a bug in the kernel, __xfrm_find_acq_byseq should only return
> XFRM_STATE_ACQ states. This patch should fix it.

Thanks - just tested the patch against the current 2.6.10 Fedora 3 kernel 
and it works well.

- Steve Hill (BSc)
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

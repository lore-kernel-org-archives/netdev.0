From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Possible overwrite in tulip driver >= 2.6.4-mm2
Date: Sat, 20 Mar 2004 06:09:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405C266D.9030706@pobox.com>
References: <4058376D.2060409@rcn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jerry Natowitz <j.natowitz@rcn.com>
In-Reply-To: <4058376D.2060409@rcn.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jerry Natowitz wrote:
> I'm not experienced in debugging kernels, so all I can do is report that
> starting in 2.6.4-mm2, I get debugging information from the tulip driver
> that I never saw before.  I've confirmed that tulip_debug *should* be 1,
> but the presence of debug messages indicate that it is being over-written.

A patch from Don Fry fixed this, I believe...  can you try with 2.6.5-rc2?

	Jeff

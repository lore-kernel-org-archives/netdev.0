From: Richard Gooch <rgooch@ras.ucalgary.ca>
Subject: Re: Poor gige performance with 2.4.20-pre*
Date: Sun, 29 Sep 2002 00:34:02 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209290634.g8T6Y2o08439@vindaloo.ras.ucalgary.ca>
References: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca>
	<002f01c2675d$b642b640$f5f2010a@weixl>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>
In-Reply-To: <002f01c2675d$b642b640$f5f2010a@weixl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Xiaoliang Wei writes:
> Hi,
>     Did you do the experiments on WAN or LAN? What's the other
> configurations, such as: The sending/receiving buffer(I think it
> should be larger than Bandwidth*Delay)?

This is all on a LAN (of course; expecting good performance from a WAN
is pretty futile). I use a buffer size of 256 KiB.

				Regards,

					Richard....
Permanent: rgooch@atnf.csiro.au
Current:   rgooch@ras.ucalgary.ca

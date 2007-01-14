From: Rainer Baumann <baumann@tik.ee.ethz.ch>
Subject: [Fwd: [Netem] [PATCH 2.6.18 0/2] LARTC: trace control for netem]
Date: Sun, 14 Jan 2007 22:40:18 +0100
Message-ID: <45AAA342.4070208@tik.ee.ethz.ch>
References: <45827B5C.3090402@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <45827B5C.3090402@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

I just wanted to ask you, if you already had time to test our trace
extension for netem as discussed on the 13th of December.

Cheers
Rainer

Rainer Baumann wrote:
> Hi Stephen
>
> As discussed yesterday, here our patches to integrate trace control into netem
>
>
>
> Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.
>
> A new option (trace) has been added to the netem command. If the trace option is used, the values for packet delay etc. are read from a pregenerated trace file, afterwards the packets are processed by the normal netem functions. The packet action values are readout from the trace file in user space and sent to kernel space via configfs.
>
>
>
>
>
>
>
> _______________________________________________
> Netem mailing list
> Netem@lists.osdl.org
> https://lists.osdl.org/mailman/listinfo/netem
>   





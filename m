From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [RFT][PATCH] Convert bluetooth to dynamic net_device.
Date: Fri, 12 Sep 2003 09:50:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20030912094654.061eb128@unixmail.qualcomm.com>
References: <20030811224851.18d41430.davem@redhat.com>
 <20030811115334.4bd4521a.shemminger@osdl.org>
 <20030811115334.4bd4521a.shemminger@osdl.org> <5.1.0.14.2.20030812094908.08cca600@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <5.1.0.14.2.20030812094908.08cca600@unixmail.qualcomm.com>
References: <20030811224851.18d41430.davem@redhat.com>
 <20030811115334.4bd4521a.shemminger@osdl.org>
 <20030811115334.4bd4521a.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 09:49 AM 8/12/2003, Max Krasnyansky wrote:
>At 10:48 PM 8/11/2003, David S. Miller wrote:
>>On Mon, 11 Aug 2003 11:53:34 -0700
>>Stephen Hemminger <shemminger@osdl.org> wrote:
>>
>>> Since the initialization code changed slightly, I would like to have
>>> someone do a basic sanity test before it is merged.
>>
>>Ok, ping me when you believe this has occurred :-)
>
>I'll test this patch and let you guys know. So far it looks ok to me.
I finally had a chance to test it. Works fine. 
So I applied the patch to my tree. 

Dave, I'm going to send you a bunch of Bluetooth updates in next email.
Those include above patch from Stephen.

Thanks
Max

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [linux-4.4-mw] BUG: unable to handle kernel paging request
 ip_vs_out.constprop
Date: Thu, 12 Nov 2015 08:52:26 -0800
Message-ID: <1447347146.22599.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <06dc952f98f54da2c4d85b31e5fa9826@eikelenboom.it>
	 <1447337353.22599.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <b95f4a06d7d9b13849ad277128690436@eikelenboom.it>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-11-12 at 16:16 +0100, Sander Eikelenboom wrote:

> > Thanks for the report, please try following patch :
> 
> Hi Eric,
> 
> Thanks for the patch!
> Got it up and running at the moment, but since i don't have a clear 
> trigger it
> will take 1 or 2 days before i can report something back.

Don't worry, I have a pretty good picture of the bug and patch must fix
it.

I'll submit it formally asap.



From: "Alec H. Peterson" <ahp@hilander.com>
Subject: Re: PCI memory reservation failure - 2.4/2.6
Date: Wed, 12 May 2004 15:35:36 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9C9F57570B19C8A682D96940@[192.168.0.100]>
References: <BDD74A21E0B47FEAC3AB8A10@[192.168.0.100]>
 <40A29211.2010707@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dominik Brodowski <linux@brodo.de>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <40A29211.2010707@colorfullife.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--On Wednesday, May 12, 2004 11:07 PM +0200 Manfred Spraul 
<manfred@colorfullife.com> wrote:

>
> I'm not sure if this is the right approach - what if a bios intentionally
> assigns a small area? It's dangerous to override the BIOS setting.
> I'd prefer a kernel command line parameter / module parameter / dmi based
> override instead of an unconditional override based on the minimum size.
> I'll think about it.

A module parameter sounds like a grand idea.  I'd be happy to take a stab 
at it if others feel it is the way to go.

Alec

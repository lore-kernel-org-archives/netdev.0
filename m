From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [0/9] via-rhine: Major surgery
Date: Wed, 16 Jun 2004 11:03:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D06148.5050602@pobox.com>
References: <20040615174732.GA10241@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040615174732.GA10241@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger Luethi wrote:
> This set of patches obsoletes all via-rhine patches for 2.6 that didn't
> make it into 2.6.7-rc3-mm2. Most notable changes: I rewrote the media,
> PHY, and link state handling and added WOL support for Rhine chips.
> 
> Patches [1/9] and [2/9] are resends so you won't have to go hunt them
> down before trying the rest.
> 
> These patches need review and testing, especially from people with
> WOL-capable hardware.

Cool.  I'll review and get into netdev-2.6 (and thus -mm) in the next 
24-48 hrs...

	Jeff

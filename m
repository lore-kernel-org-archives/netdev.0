From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] Nuke HAS_IP_COPYSUM for net drivers
Date: Thu, 27 May 2004 13:36:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40B62710.8010602@pobox.com>
References: <20040525191115.GA18454@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Roger Luethi <rl@hellgate.ch>
In-Reply-To: <20040525191115.GA18454@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Roger Luethi wrote:
> Entirely untested, but Obviously Correct(TM). HAS_IP_COPYSUM has been
> utterly meaningless for a long time.

I will apply to netdev-2.6 queue, which means it will get testing and 
review via Andrew's -mm tree.

After 2.6.7 is released, I'll push upstream.


> Respective patch for via-rhine follows once I know the state of its
> pending patches (which I wouldn't mind getting feedback on (hint,
> hint!)).

Working through the backlog today, yell at me if you haven't heard 
anything by the end of the day :)

	Jeff

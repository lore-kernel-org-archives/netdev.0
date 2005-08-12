From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH 0/8] netpoll: various bugfixes
Date: Fri, 12 Aug 2005 21:31:09 +0200
Message-ID: <20050812193109.GA15434__31744.9657516137$1123875257$gmane$org@suse.de>
References: <1.502409567@selenic.com> <20050812172151.GA11104@suse.de> <20050812192152.GJ12284@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20050812192152.GJ12284@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Fri, Aug 12, Matt Mackall wrote:

> Does the task dump work without patch 5/8 (add retry timeout)? I'll
> try testing it here.

I spoke to soon, worked once, after reboot not anymore. Will try to play
with individual patches. Does the task dump work for you, at least?

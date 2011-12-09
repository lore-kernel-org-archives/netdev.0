From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 4/9] tcp memory pressure controls
Date: Fri, 9 Dec 2011 10:51:07 +0900
Message-ID: <20111209105107.0e2296c1.kamezawa.hiroyu@jp.fujitsu.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com,
 ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com,
 netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name,
 avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com,
 cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, KAMEZAWA
 Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1323120903-2831-5-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Mon,  5 Dec 2011 19:34:58 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch introduces memory pressure controls for the tcp
> protocol. It uses the generic socket memory pressure code
> introduced in earlier patches, and fills in the
> necessary data in cg_proto struct.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

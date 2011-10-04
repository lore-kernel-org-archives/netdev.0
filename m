From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 5/8] per-netns ipv4 sysctl_tcp_mem
Date: Tue, 4 Oct 2011 10:18:40 +0900
Message-ID: <20111004101840.442e3c4a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-6-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org,
	lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net,
	gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org,
	kirill@shutemov.name, avagin@parallels.com
To: Glauber Costa <glommer@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317637123-18306-6-git-send-email-glommer@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  3 Oct 2011 14:18:40 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch allows each namespace to independently set up
> its levels for tcp memory pressure thresholds. This patch
> alone does not buy much: we need to make this values
> per group of process somehow. This is achieved in the
> patches that follows in this patchset.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

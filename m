From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NetLabel: audit fixups due to delayed feedback
Date: Fri, 29 Sep 2006 17:05:43 -0700 (PDT)
Message-ID: <20060929.170543.90121035.davem@davemloft.net>
References: <20060929223948.975556000@hp.com> <20060929224355.253290000@hp.com>
	<200609292000.42544.sgrubb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
Return-path: <linux-audit-bounces@redhat.com>
To: sgrubb@redhat.com
In-Reply-To: <200609292000.42544.sgrubb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Steve Grubb <sgrubb@redhat.com>
Date: Fri, 29 Sep 2006 20:00:42 -0400

> On Friday 29 September 2006 18:39, paul.moore@hp.com wrote:
> > This should make NetLabel more consistent with other kernel
> > generated audit messages specifying configuration changes.
> 
> OK, this looks better. We may fine tune the messages later after we try it 
> out, but all the issues I saw are fixed.    ACK.

Patch applied.

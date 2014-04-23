From: Richard Guy Briggs <rgb@redhat.com>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Tue, 22 Apr 2014 21:49:29 -0400
Message-ID: <20140423014929.GL20182@madcap2.tricolour.ca>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
	<cover.1398215388.git.rgb@redhat.com>
	<20140422.214300.171999077259349189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
        hadi@mojatatu.com
To: David Miller <davem@davemloft.net>, linux-audit@redhat.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-audit-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20140422.214300.171999077259349189.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On 14/04/22, David Miller wrote:
> From: Richard Guy Briggs <rgb@redhat.com>
> Date: Tue, 22 Apr 2014 21:31:52 -0400
> 
> > This is a patch set Eric Paris and I have been working on to add a restricted
> > capability read-only netlink multicast socket to kernel audit to enable
> > userspace clients such as systemd/journald to receive audit logs, in addition
> > to the bidirectional auditd userspace client.
> 
> Series applied, thanks Richard.

Thanks for your patience, David.  Can I assume you adopted the 3 audit
patches too, becuase of the dependence?

- RGB

--
Richard Guy Briggs <rbriggs@redhat.com>
Senior Software Engineer, Kernel Security, AMER ENG Base Operating Systems, Red Hat
Remote, Ottawa, Canada
Voice: +1.647.777.2635, Internal: (81) 32635, Alt: +1.613.693.0684x3545

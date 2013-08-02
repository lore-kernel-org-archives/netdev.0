From: Paul Moore <pmoore@redhat.com>
Subject: Re: [Patch net-next v2 8/8] selinux: use generic union inet_addr
Date: Fri, 02 Aug 2013 10:34:07 -0400
Message-ID: <4528870.px4VD3WrY3@sifl>
References: <1375427674-21735-1-git-send-email-amwang@redhat.com> <1375427674-21735-9-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1375427674-21735-9-git-send-email-amwang@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, August 02, 2013 03:14:34 PM Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
> 
> selinux has some similar definition like union inet_addr,
> it can re-use the generic union inet_addr too.
> 
> Cc: James Morris <james.l.morris@oracle.com>
> Cc: Stephen Smalley <sds@tycho.nsa.gov>
> Cc: Eric Paris <eparis@parisplace.org>
> Cc: Paul Moore <pmoore@redhat.com>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-security-module@vger.kernel.org
> Signed-off-by: Cong Wang <amwang@redhat.com>

Perhaps I'm confusing this with another patch but I though DaveM said he 
wasn't going to merge these patches?

-- 
paul moore
security and virtualization @ redhat


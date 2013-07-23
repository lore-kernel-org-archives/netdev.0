From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 7/7] selinux: use generic union inet_addr
Date: Tue, 23 Jul 2013 10:07:32 +0800
Message-ID: <1374545252.24933.6.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-8-git-send-email-amwang@redhat.com>
	 <15803221.LSzpdzDYPS@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	James Morris <james.l.morris@oracle.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Paul Moore <pmoore@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <15803221.LSzpdzDYPS@sifl>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-22 at 16:36 -0400, Paul Moore wrote:
> 
> These changes are going to affect Smack as well.  You either need to respin 
> this patch to include all of the LSMs (Smack should be the only other affected 
> LSM) or add a new patch to the patchset.
> 

Yeah, I will include the Smack part as well.

Thanks!


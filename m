From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 0/3] selinux: add missing xfrm nl cmd
Date: Fri, 10 Apr 2015 16:24:25 +0200
Message-ID: <1428675868-11790-1-git-send-email-nicolas.dichtel@6wind.com>
References: <55267162.7050304@tycho.nsa.gov>
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, paul@paul-moore.com
To: davem@davemloft.net, sds@tycho.nsa.gov
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55267162.7050304@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


With this series, xfrm commands are fully synchronized.

 security/selinux/nlmsgtab.c | 3 +++
 1 file changed, 3 insertions(+)

Regards,
Nicolas

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Tue, 22 Apr 2014 21:43:00 -0400 (EDT)
Message-ID: <20140422.214300.171999077259349189.davem@davemloft.net>
References: <20140422.161904.1187535812839850973.davem@davemloft.net>
	<cover.1398215388.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, jamal@mojatatu.com,
	eparis@redhat.com, sgrubb@redhat.com
To: rgb@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <cover.1398215388.git.rgb@redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue, 22 Apr 2014 21:31:52 -0400

> This is a patch set Eric Paris and I have been working on to add a restricted
> capability read-only netlink multicast socket to kernel audit to enable
> userspace clients such as systemd/journald to receive audit logs, in addition
> to the bidirectional auditd userspace client.

Series applied, thanks Richard.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6][v2] audit: implement multicast socket for journald
Date: Tue, 22 Apr 2014 23:55:15 -0400 (EDT)
Message-ID: <20140422.235515.1172733305552022632.davem@davemloft.net>
References: <cover.1398215388.git.rgb@redhat.com>
	<20140422.214300.171999077259349189.davem@davemloft.net>
	<20140423014929.GL20182@madcap2.tricolour.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, hadi@mojatatu.com,
	eparis@redhat.com, sgrubb@redhat.com
To: rgb@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140423014929.GL20182@madcap2.tricolour.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Guy Briggs <rgb@redhat.com>
Date: Tue, 22 Apr 2014 21:49:29 -0400

> On 14/04/22, David Miller wrote:
>> From: Richard Guy Briggs <rgb@redhat.com>
>> Date: Tue, 22 Apr 2014 21:31:52 -0400
>> 
>> > This is a patch set Eric Paris and I have been working on to add a restricted
>> > capability read-only netlink multicast socket to kernel audit to enable
>> > userspace clients such as systemd/journald to receive audit logs, in addition
>> > to the bidirectional auditd userspace client.
>> 
>> Series applied, thanks Richard.
> 
> Thanks for your patience, David.  Can I assume you adopted the 3 audit
> patches too, becuase of the dependence?

Yes.

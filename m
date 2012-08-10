From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: [Question]About KVM network zero-copy  feature!
Date: Fri, 10 Aug 2012 11:34:32 +0800
Message-ID: <50248148.4070204@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <kvm@vger.kernel.org>, <avi@redhat.com>, <mtosatti@redhat.com>,
	<mst@redhat.com>, <virtualization@lists.linux-foundation.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:35844 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760131Ab2HJDgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 23:36:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,All

I searched from git-log, and found that until now we have vhost TX zero-copy experiment feature, how
about RX zero-copy?

For XEN, net-back also only has TX zero-copy, Is there any reason that RX zero-copy still not implemented?

Thanks!

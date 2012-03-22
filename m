From: David Miller <davem@davemloft.net>
Subject: Re: [PULL] vhost-net/virtio: fixes for 3.4
Date: Thu, 22 Mar 2012 16:56:49 -0400 (EDT)
Message-ID: <20120322.165649.32205268396882350.davem@davemloft.net>
References: <20120320145010.GA31570@redhat.com>
	<20120322082718.GA11258@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	levinsasha928@gmail.com, nyh@il.ibm.com, nyh@math.technion.ac.il
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756892Ab2CVU5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 16:57:11 -0400
In-Reply-To: <20120322082718.GA11258@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Thu, 22 Mar 2012 10:27:19 +0200

> On Tue, Mar 20, 2012 at 04:50:41PM +0200, Michael S. Tsirkin wrote:
>> The following changes since commit 5ffca28a4ac7abb8a254fafe6bd03b2f83667df7:
>> 
>>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/aia21/ntfs (2012-02-27 07:59:33 -0800)
>> 
>> are available in the git repository at:
>> 
>>   ra.kernel.org:/pub/scm/linux/kernel/git/mst/vhost.git for_davem
>> 
>>   (ssh url as git.kernel.org seems down at the moment, when it comes up
>>    git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_davem
>>    should be the equivalent).

Neither of these URL's work for me:

[davem@drr net]$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_davem
fatal: Couldn't find remote ref for_davem
[davem@drr net]$ git pull ra.kernel.org:/pub/scm/linux/kernel/git/mst/vhost.git for_davem
Enter passphrase for key '/home/davem/.ssh/davem': 
Permission denied (publickey).
fatal: The remote end hung up unexpectedly
[davem@drr net]$ 

If you're sending me signed pull requests that thus require a newer
version of GIT, please don't.

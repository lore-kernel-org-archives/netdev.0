From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: linux-next: manual merge of the driver-core tree with the net tree
Date: Fri, 21 May 2010 00:43:55 -0700
Message-ID: <m1pr0pwvgk.fsf@fess.ebiederm.org>
References: <20100521162134.6b6326bd.sfr@canb.auug.org.au>
	<m1tyq1wy4h.fsf@fess.ebiederm.org>
	<20100520.235008.97331614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfr@canb.auug.org.au, greg@kroah.com, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100520.235008.97331614.davem@davemloft.net> (David Miller's message of "Thu\, 20 May 2010 23\:50\:08 -0700 \(PDT\)")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Thu, 20 May 2010 23:46:22 -0700
>
>> It looks right, except perhaps the RPS code looks like it will cause a
>> build failure with sysfs disabled, but that has nothing to do with your
>> changes.
>
> CONFIG_RPS depends upon CONFIG_SMP && CONFIG_SYSFS, so no that build
> failure is not possible.

That's the bit I'm missing.  My apologies if I caused any unnecessary worry.

Eric

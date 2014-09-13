From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to
 virtqueue_add_*()
Date: Sat, 13 Sep 2014 12:53:41 -0400 (EDT)
Message-ID: <20140913.125341.1440485569100220563.davem@davemloft.net>
References: <1410396458-1165-2-git-send-email-rusty@rustcorp.com.au>
	<20140912.175440.1013837932148725302.davem@davemloft.net>
	<87ioksgjt8.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87ioksgjt8.fsf@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 13 Sep 2014 15:10:03 +0930

> David Miller <davem@davemloft.net> writes:
>> Do you guys want me to take this series directly into net-next?
> 
> Actually, yes.  Since I'm going to be travelling, that makes it much
> easier for me.  And no other patches I have depend on it.

Series applied, but can you be more careful when you hand edit patches
or whatever you are doing that puts space characters at the beginning
of lines before TAB characters?

GIT flags this immediately, so even if you are hella lazy just feeding
your patches into "git am" will show this.

Thanks.

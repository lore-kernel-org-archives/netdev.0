From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv9 3/3] vhost_net: a kernel-level virtio server
Date: Thu, 12 Nov 2009 12:48:37 +1030
Message-ID: <200911121248.38365.rusty@rustcorp.com.au>
References: <cover.1257786516.git.mst@redhat.com> <200911101349.09783.rusty@rustcorp.com.au> <20091110113637.GB6989@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
 virtualization@lists.linux-foundation.org,
 kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 mingo@elte.hu,
 linux-mm@kvack.org,
 akpm@linux-foundation.org,
 hpa@zytor.com,
 gregory.haskins@gmail.com,
 s.hetze@linux-ag.com,
 Daniel Walker <dwalker@fifo99.com>,
 Eric Dumazet <eric.dumazet@gmail.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20091110113637.GB6989@redhat.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Nov 2009 10:06:37 pm Michael S. Tsirkin wrote:
> If tun is a module, vhost must be a module, too.
> If tun is built-in or disabled, vhost can be built-in.

I really like the brainbending :)  Keeps readers on their toes...

Applied,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

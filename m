From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 8/8] drivers:net:misc: Remove unnecessary alloc/OOM
	messages
Date: Thu, 07 Feb 2013 14:38:52 +1030
Message-ID: <87lib0ix4b.fsf@rustcorp.com.au>
References: <cover.1359939012.git.joe@perches.com>
	<a729555c8acf2cc3ef4c80531757b37a948c4e55.1359939013.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Joerg Reuter <jreuter@yaina.de>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <a729555c8acf2cc3ef4c80531757b37a948c4e55.1359939013.git.joe@perches.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> alloc failures already get standardized OOM
> messages and a dump_stack.
>
> Signed-off-by: Joe Perches <joe@perches.com>

Why not, less code is always good.

Acked-by: Rusty Russell <rusty@rustcorp.com.au> (virtio_net)

Cheers,
Rusty.

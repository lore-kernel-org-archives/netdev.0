From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] VSOCK: Split vm_sockets.h into kernel/uapi
Date: Fri, 08 Mar 2013 01:09:18 +0000
Message-ID: <29364.1362704958@warthog.procyon.org.uk>
References: <20130307232453.GD10304@kroah.com>
	<1362669973-26984-1-git-send-email-acking@vmware.com>
	<26621.1362675490@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andy King <acking@vmware.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, dhowells@redhat.com,
	davem@davemloft.net
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130307232453.GD10304@kroah.com>
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

Greg KH <gregkh@linuxfoundation.org> wrote:

> David, is there any rush to get stuff like this into 3.9 for any
> uapi-type changes, or can it just wait for 3.10?

Not especially.  It won't appear in userspace due to the __KERNEL__ guards.

David

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Split vm_sockets.h into kernel/uapi
Date: Fri, 08 Mar 2013 12:26:10 -0500 (EST)
Message-ID: <20130308.122610.415557290822516252.davem@davemloft.net>
References: <1362669973-26984-1-git-send-email-acking@vmware.com>
	<26621.1362675490@warthog.procyon.org.uk>
	<29364.1362704958@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: acking@vmware.com, pv-drivers@vmware.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: dhowells@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <29364.1362704958@warthog.procyon.org.uk>
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

From: David Howells <dhowells@redhat.com>
Date: Fri, 08 Mar 2013 01:09:18 +0000

> Greg KH <gregkh@linuxfoundation.org> wrote:
> 
>> David, is there any rush to get stuff like this into 3.9 for any
>> uapi-type changes, or can it just wait for 3.10?
> 
> Not especially.  It won't appear in userspace due to the __KERNEL__ guards.

I've applied this to net-next, thanks.

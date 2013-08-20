From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vhost: Include linux/uio.h instead of linux/socket.h
Date: Tue, 20 Aug 2013 15:08:10 -0700 (PDT)
Message-ID: <20130820.150810.2276780972263433709.davem@davemloft.net>
References: <20130816.222946.421410239742571372.davem@davemloft.net>
	<1376875399-21945-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, mst@redhat.com
To: asias@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1376875399-21945-1-git-send-email-asias@redhat.com>
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

From: Asias He <asias@redhat.com>
Date: Mon, 19 Aug 2013 09:23:19 +0800

> memcpy_fromiovec is moved from net/core/iovec.c to lib/iovec.c.
> linux/uio.h provides the declaration for memcpy_fromiovec.
> 
> Include linux/uio.h instead of inux/socket.h for it.
> 
> Signed-off-by: Asias He <asias@redhat.com>

Applied.

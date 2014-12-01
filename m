From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] vhost: remove unnecessary forward declarations
	in vhost.h
Date: Mon, 01 Dec 2014 05:42:47 +0008
Message-ID: <1417412087.7521.1@smtp.corp.redhat.com>
References: <1417070481-10331-1-git-send-email-jasowang@redhat.com>
	<20141129.210422.2298555198780052887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141129.210422.2298555198780052887.davem@davemloft.net>
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



On Sun, Nov 30, 2014 at 1:04 PM, David Miller <davem@davemloft.net> 
wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Thu, 27 Nov 2014 14:41:21 +0800
> 
>>  Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> I don't think generic vhost patches should go via my tree.
> 
> If you disagree, let me know why, thanks :)

Agree. Michael, could you pls pick this into vhost tree?

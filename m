From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] vhost: Remove duplicate inclusion of linux/vhost.h
Date: Mon, 19 Nov 2012 14:51:59 -0500 (EST)
Message-ID: <20121119.145159.1150580275863654560.davem@davemloft.net>
References: <1353324508-22083-1-git-send-email-sachin.kamat@linaro.org>
	<20121119.141813.2249570877638146916.davem@davemloft.net>
	<20121119194954.GA12283@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, patches@linaro.org, sachin.kamat@linaro.org,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20121119194954.GA12283@redhat.com>
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

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 19 Nov 2012 21:49:55 +0200

> On Mon, Nov 19, 2012 at 02:18:13PM -0500, David Miller wrote:
>> From: Sachin Kamat <sachin.kamat@linaro.org>
>> Date: Mon, 19 Nov 2012 16:58:28 +0530
>> 
>> > linux/vhost.h was included twice.
>> > 
>> > Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
>> 
>> Michael, are you gonna take this?
>> 
>> Thanks.
> 
> Pls pick it up.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next, thanks.

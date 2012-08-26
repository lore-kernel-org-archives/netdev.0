From: Stefan Hajnoczi <stefanha@gmail.com>
Subject: Re: [PATCH] vhost: remove duplicated include from tcm_vhost.c
Date: Sun, 26 Aug 2012 08:22:12 +0100
Message-ID: <CAJSP0QX+vKsZq3+v6ez7URTRUfVJ4gRfCeMqKsHW+cJ=YijWTw@mail.gmail.com>
References: <CAPgLHd-GRu8Dc3bxLL4ogjsE6gY=OS7n0H-5JFyMi_dy2OXP9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yongjun_wei@trendmicro.com.cn,
	virtualization@lists.linux-foundation.org, kvm@vger.kernel.org,
	mst@redhat.com
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <CAPgLHd-GRu8Dc3bxLL4ogjsE6gY=OS7n0H-5JFyMi_dy2OXP9g@mail.gmail.com>
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

On Sun, Aug 26, 2012 at 2:42 AM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Remove duplicated include.
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/vhost/tcm_vhost.c | 1 -
>  1 file changed, 1 deletion(-)

Reviewed-by: Stefan Hajnoczi <stefanha@linux.vnet.ibm.com>

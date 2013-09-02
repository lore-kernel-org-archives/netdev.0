From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 1/6] vhost_net: make vhost_zerocopy_signal_used()
	returns void
Date: Mon, 02 Sep 2013 14:29:07 +0800
Message-ID: <52243033.9000309@redhat.com>
References: <1377836962-49780-1-git-send-email-jasowang@redhat.com>
	<1377836962-49780-2-git-send-email-jasowang@redhat.com>
	<20130902055118.GB19838@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130902055118.GB19838@redhat.com>
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

On 09/02/2013 01:51 PM, Michael S. Tsirkin wrote:
> tweak subj s/returns/return/
>
> On Fri, Aug 30, 2013 at 12:29:17PM +0800, Jason Wang wrote:
>> > None of its caller use its return value, so let it return void.
>> > 
>> > Signed-off-by: Jason Wang <jasowang@redhat.com>
>> > ---

Will correct it in v3.

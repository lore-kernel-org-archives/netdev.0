From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: do not rate limit counter increments
Date: Wed, 28 Mar 2012 04:41:06 -0400 (EDT)
Message-ID: <20120328.044106.1637549637532712494.davem@davemloft.net>
References: <20120327172809.C52572900384@tardy>
	<20120328083046.GA5873@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rick.jones2@hp.com,
	virtualization@lists.linux-foundation.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120328083046.GA5873@redhat.com>
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
Date: Wed, 28 Mar 2012 10:30:46 +0200

> On Tue, Mar 27, 2012 at 10:28:09AM -0700, Rick Jones wrote:
>> From: Rick Jones <rick.jones2@hp.com>
>> 
>> While it is desirable to rate limit certain messages, it is not
>> desirable to rate limit the incrementing of counters associated
>> with those messages.
>> 
>> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Dave, can you apply pls? Thanks!

Done.

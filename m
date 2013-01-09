From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Tue, 08 Jan 2013 17:30:56 -0800 (PST)
Message-ID: <20130108.173056.1029788106028104571.davem@davemloft.net>
References: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
	<20130109002110.GB5296@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
To: gregkh@linuxfoundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130109002110.GB5296@kroah.com>
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

From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 8 Jan 2013 16:21:10 -0800

> On Tue, Jan 08, 2013 at 03:59:08PM -0800, George Zhang wrote:
>> 
>> * * *
>> 
>> This series of VSOCK linux upstreaming patches include latest udpate from
>> VMware to address Greg's and all other's code review comments.
> 
> Dave, you acked these patches a while ago,

Really?  I'd like to see where I did that.

Instead, what I remember doing was deferring to the feedback these
folks received, stating that ideas that the virtio people had
mentioned should be considered instead.

http://marc.info/?l=linux-netdev&m=135301515818462&w=2

So definitely NACK this code and any infrastructure you've
merged which essentialy depends upon it.

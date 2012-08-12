From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Sun, 12 Aug 2012 12:37:31 +0300
Message-ID: <20120812093730.GD1421@redhat.com>
References: <50248148.4070204@huawei.com>
	<20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
	<5026D49B.10305@tuffmail.com> <5026FC04.6080108@tuffmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	"Peter Huang\(Peng\)" <peter.huangpeng@huawei.com>,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: Robert Vineyard <vineyard@tuffmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <5026FC04.6080108@tuffmail.com>
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

On Sat, Aug 11, 2012 at 08:42:44PM -0400, Robert Vineyard wrote:
> (adding Xin Xiaohui to the conversation for comment)
> 
> According to the NetworkingTodo page on the KVM wiki, zero-copy RX
> for macvtap is in fact on the roadmap, assigned to Xin:
> 
> http://www.linux-kvm.org/page/NetworkingTodo

AFAIK Xin left Intel and is not working on it.
Contributions are welcome.

> The Release Notes for RHEL 6.2 (originally published on 12/06/2011)
> also specifically mention macvtap/vhost zero-copy capabilities as
> being included as a Technology Preview:
> 
> http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/6.2_Release_Notes/virtualization.html
> 
> Since I've been unable to find much information on the current
> status of this development, can anyone confirm if this functionality
> is still in the works? If so, is there any planned ETA?
> 
> Thanks,
> Robert Vineyard

I think this means TX.

-- 
MST

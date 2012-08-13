From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: Re: [Question]About KVM network zero-copy  feature!
Date: Mon, 13 Aug 2012 09:24:54 +0800
Message-ID: <50285766.50307@huawei.com>
References: <50248148.4070204@huawei.com>
	<20120811135556.58ddf48d@nehalam.linuxnetplumber.net>
	<5026D49B.10305@tuffmail.com> <5026FC04.6080108@tuffmail.com>
	<20120812093730.GD1421@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120812093730.GD1421@redhat.com>
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

Hi, Michael

IIt will be usefull if we can implement rx zero-copy, could you give
 me some help if you know some technical details or some
references on the internet?

I am wondering may be I can take a deep look on it first then decide
if I can take it over or not.

Thanks a lot.

On 2012/8/12 17:37, Michael S. Tsirkin wrote:
> On Sat, Aug 11, 2012 at 08:42:44PM -0400, Robert Vineyard wrote:
>> (adding Xin Xiaohui to the conversation for comment)
>>
>> According to the NetworkingTodo page on the KVM wiki, zero-copy RX
>> for macvtap is in fact on the roadmap, assigned to Xin:
>>
>> http://www.linux-kvm.org/page/NetworkingTodo
> AFAIK Xin left Intel and is not working on it.
> Contributions are welcome.
>

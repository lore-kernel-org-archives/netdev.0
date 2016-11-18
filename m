From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Fri, 18 Nov 2016 16:40:11 +0000
Message-ID: <034e8607-b6d1-02e9-6ec3-fe50f1bd51c8@synopsys.com>
References: <cbe5f79b-53a4-e116-1e09-bc975a66a8ca@synopsys.com>
 <771E7B93-5AB6-4F2B-8DEB-58DDB6A96D13@gmail.com>
 <fbf4263b-2b08-611d-f9cb-1f09c6f91117@synopsys.com>
 <a4bb3828-3aa5-1e80-f57e-ad9a94a681b3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <andreas.irestal@axis.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>,
        <jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
        <saeedm@mellanox.com>, <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a4bb3828-3aa5-1e80-f57e-ad9a94a681b3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18-11-2016 16:35, Florian Fainelli wrote:
> 
> 
> On 11/18/2016 08:31 AM, Joao Pinto wrote:
>>  Hi Florian,
>>
>> On 18-11-2016 14:53, Florian Fainelli wrote:
>>> On November 18, 2016 4:28:30 AM PST, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
>>>>

snip (...)

>>>> I would also gladly be available to be its maintainer if you agree with
>>>> it.
>>>
>>> Since you have both the hardware and a clear todo list for this driver, start submitting patches, get them included in David's tree and over time chances are that you will become the maintainer, either explicitly by adding an entry in the MAINTAINERS file or just by consistently contributing to this area.
>>
>> Thanks for the feedback.
>>
>> So I found 2 suitable git trees:
>>  a) kernel/git/davem/net.git
>>  b) kernel/git/davem/net-next.git
>>
>> We should submit to net.git correct? The net-next.git is a tree with selected
>> patches for upstream only?
> 
> net-next.git is the git tree where new features/enhancements can be
> submitted, while net.git is for bug fixes. Unless you absolutely need
> to, it is common practice to avoid having changes in net-next.git depend
> on net.git and vice versa.
> 
> Hope this helps.
> 

help a lot, thank you!
lets start working then :)

Thanks,
Joao

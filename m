From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: Synopsys Ethernet QoS Driver
Date: Fri, 18 Nov 2016 16:31:00 +0000
Message-ID: <fbf4263b-2b08-611d-f9cb-1f09c6f91117@synopsys.com>
References: <cbe5f79b-53a4-e116-1e09-bc975a66a8ca@synopsys.com>
 <771E7B93-5AB6-4F2B-8DEB-58DDB6A96D13@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <CARLOS.PALMINHA@synopsys.com>, <andreas.irestal@axis.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>, <davem@davemloft.net>,
        <jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
        <saeedm@mellanox.com>, <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <771E7B93-5AB6-4F2B-8DEB-58DDB6A96D13@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hi Florian,

On 18-11-2016 14:53, Florian Fainelli wrote:
> On November 18, 2016 4:28:30 AM PST, Joao Pinto <Joao.Pinto@synopsys.com> wrote:
>>
>> Dear all,
>>
>> My name is Joao Pinto and I work at Synopsys.
>> I am a kernel developer with special focus in mainline collaboration,
>> both Linux
>> and Buildroot. I was recently named one of the maintainers of the PCIe
>> Designware core driver and I was the author of the Designware UFS
>> driver stack.
>>
>> I am sending you this e-mail because you were the suggested contacts
>>from the
>> get_maintainers script concerning Ethernet drivers :).
>>
>> Currently I have the task to work on the mainline Ethernet QoS driver
>> in which
>> you are the author. The work would consist of the following:
>>
>> a) Separate the current driver in a Core driver (common ops) + platform
>> glue
>> driver + pci glue driver
>> b) Add features that are currently only available internally
>> c) Add specific phy support using the PHY framework
>>
>> I would also gladly be available to be its maintainer if you agree with
>> it.
> 
> Since you have both the hardware and a clear todo list for this driver, start submitting patches, get them included in David's tree and over time chances are that you will become the maintainer, either explicitly by adding an entry in the MAINTAINERS file or just by consistently contributing to this area.

Thanks for the feedback.

So I found 2 suitable git trees:
 a) kernel/git/davem/net.git
 b) kernel/git/davem/net-next.git

We should submit to net.git correct? The net-next.git is a tree with selected
patches for upstream only?

> 

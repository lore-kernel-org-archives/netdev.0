From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v2 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Mon, 17 Oct 2011 08:41:25 -0700
Message-ID: <4E9C4CA5.8020407@cavium.com>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com> <20110929.163112.1523715692737597332.davem@davemloft.net> <20110930003214.GB12606@ponder.secretlab.ca> <C81814FF-4E56-4B28-8043-F874EE1D6B51@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>,
	devicetree-discuss@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C81814FF-4E56-4B28-8043-F874EE1D6B51@kernel.crashing.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2011 07:48 AM, Kumar Gala wrote:
>
> On Sep 29, 2011, at 7:32 PM, Grant Likely wrote:
>
>> On Thu, Sep 29, 2011 at 04:31:12PM -0400, David Miller wrote:
>>> From: David Daney<david.daney@cavium.com>
>>> Date: Tue, 27 Sep 2011 16:26:52 -0700
>>>
>>>> v2: Update bindings to use "reg" and "mdio-parent-bus" insutead of
>>>>     "cell-index" and "parent-bus"
>>>
>>> Grant, when the final version of this patch set is ready how do
>>> you want to handle merging it in?
>>>
>>> I think it would be safe to merge this via your tree, since the
>>> changes made to existing network driver files are rather trivial and
>>> thus merge conflict friendly.
>>
>> Your tree or mine, I'm happy either way.  Even if there were
>> conflicts, they would be trivial.
>>
>> Sure, I'll take care of merging it when I see an ack from you.
>>
>>> Actually, I feel like we've discussed this before :-)
>>
>> :)
>>
>> g.
>
> Any updates to these patches?

Not yet, so you didn't miss anything.

They are on my to-do list though

David Daney

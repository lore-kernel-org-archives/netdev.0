From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH v2 0/3] netdev/of/phy: MDIO bus multiplexer support.
Date: Mon, 17 Oct 2011 09:48:47 -0500
Message-ID: <C81814FF-4E56-4B28-8043-F874EE1D6B51@kernel.crashing.org>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com>
 <20110929.163112.1523715692737597332.davem@davemloft.net>
 <20110930003214.GB12606@ponder.secretlab.ca>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20110930003214.GB12606-e0URQFbLeQY2iJbIjFUEsiwD8/FfD2ys@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org


On Sep 29, 2011, at 7:32 PM, Grant Likely wrote:

> On Thu, Sep 29, 2011 at 04:31:12PM -0400, David Miller wrote:
>> From: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
>> Date: Tue, 27 Sep 2011 16:26:52 -0700
>> 
>>> v2: Update bindings to use "reg" and "mdio-parent-bus" insutead of
>>>    "cell-index" and "parent-bus"
>> 
>> Grant, when the final version of this patch set is ready how do
>> you want to handle merging it in?
>> 
>> I think it would be safe to merge this via your tree, since the
>> changes made to existing network driver files are rather trivial and
>> thus merge conflict friendly.
> 
> Your tree or mine, I'm happy either way.  Even if there were
> conflicts, they would be trivial.
> 
> Sure, I'll take care of merging it when I see an ack from you.
> 
>> Actually, I feel like we've discussed this before :-)
> 
> :)
> 
> g.

Any updates to these patches?

- k

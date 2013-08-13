From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH V2 0/4] Enable bus master till the FLR completes for
 Chelsio T4
Date: Tue, 13 Aug 2013 17:00:40 -0600
Message-ID: <CAErSpo7jt485wC15yV7eWs0XEs90xQyvPGNyMCUCK3qmQkk71Q@mail.gmail.com>
References: <1375784319-25760-1-git-send-email-vipul@chelsio.com>
 <CAErSpo7=oBG3tJBpwscnL-4D-9kLhHUrQSZFrRRC4sBsT2_U2Q@mail.gmail.com> <520AAADF.7080801@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vipul Pandya <vipul@chelsio.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	tomreu@chelsio.com, divy@chelsio.com, dm@chelsio.com,
	nirranjan@chelsio.com, eilong@broadcom.com,
	netdev <netdev@vger.kernel.org>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <520AAADF.7080801@chelsio.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 13, 2013 at 3:53 PM, Casey Leedom <leedom@chelsio.com> wrote:
>
> On 08/12/13 14:17, Bjorn Helgaas wrote:
>>
>> On Tue, Aug 6, 2013 at 4:18 AM, Vipul Pandya <vipul@chelsio.com> wrote:
>>>
>>> This patch series adds device specific reset method for Chelsio T4
>>> adapters.
>>>
>>> ...
>>
>> Applied to my "next" branch for v3.12, thanks!
>>
>
>   Thanks Bjorn!  Do you have an idea when these commits will hit Linus'
> repository and what their git commit IDs will be?  We have a customer using
> SLES11sp2 who needs this and once the commits hit Linus' repository we'll
> need to send a request to Novell to pull the change sets into SLES11sp2.

They should appear in Linus' repository a few days after the v3.11
release, which will likely be in the first half of September.

The commit IDs should be the same as those in my repo, which you can
see here: http://git.kernel.org/cgit/linux/kernel/git/helgaas/pci.git/log/?h=pci/vipul-chelsio-reset-v2

Bjorn

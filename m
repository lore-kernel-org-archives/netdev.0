From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] DT: net: document Ethernet bindings in one place
Date: Thu, 30 Jan 2014 02:04:26 +0300
Message-ID: <52E988FA.8040807@cogentembedded.com>
References: <201401180405.07859.sergei.shtylyov@cogentembedded.com> <CAL_Jsq+oa9P=rh+p-dMZyGP8TcmpX7bTnMU0ynLvFxjxFDYbRg@mail.gmail.com> <52DD98F7.4090202@cogentembedded.com> <CAL_JsqJXbF1-PcPHR2VP+Vi9A1aWizdsG_r3kDvRt3itXDhCGQ@mail.gmail.com> <CAGVrzcb3X3soJNJCE5+YSpQrr+EdycCRFkptPvBCgFg4CbGJ4Q@mail.gmail.com> <CAGVrzcb0dfw1orZzUt5-YkShOg-HNbUYvvo2vfmsZUZXy1Aqfg@mail.gmail.com> <52DEE465.9000202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Grant Likely <grant.likely@linaro.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Rob Herring <robherring2@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <52DEE465.9000202@cogentembedded.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 01/22/2014 12:19 AM, Sergei Shtylyov wrote:

>>>>>     I'm afraid that's too late, it has spread very far, so that
>>>>> of_get_phy_mode() handles that property, not "phy-connection-type".

>>>> Uggg, I guess this is a case of a defacto standard then if the kernel
>>>> doesn't even support it.

>>> Maybe I forgot to CC you on patch sent to Grant only, I sent a patch a
>>> while ago for of_get_phy_mode() to look for both "phy-mode" and
>>> "phy-connection-type" since the former has been a Linux invention, but
>>> the latter is ePAPR specified.

>> Here is a link to the actual patch in question, not sure which tree
>> Grant applied it to though:

>> http://lkml.indiana.edu/hypermail/linux/kernel/1311.2/00048.html

>     It's not the patch mail, it's Grant's "applied" reply, patch is mangled in
> this reply, and I couldn't follow the thread. Here's the actual patch mail:

> http://marc.info/?l=devicetree&m=138449662807254

    Florian, I didn't find this patch in Grant's official tree, so maybe you 
should ask him where is the patch already?

WBR, Sergei


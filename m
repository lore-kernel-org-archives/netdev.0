From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next v2 8/9] Altera TSE: Add Miscellaneous Files for
 Altera Ethernet Driver
Date: Tue, 11 Mar 2014 10:33:45 -0500
Message-ID: <CAOwfj2PekMTsc+r6bBGrSxUbmUD+BhvTfWomCuDuST5qgc0=Yg@mail.gmail.com>
References: <1394493277-2105-1-git-send-email-vbridgers2013@gmail.com>
	<1394493277-2105-9-git-send-email-vbridgers2013@gmail.com>
	<20140310173836.5845b01c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Rob Landley <rob@landley.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140310173836.5845b01c@nehalam.linuxnetplumber.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 7:38 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Mon, 10 Mar 2014 18:14:36 -0500
> Vince Bridgers <vbridgers2013@gmail.com> wrote:
>
>> +static char stat_gstrings[][ETH_GSTRING_LEN] = {
>> +     "aFramesTransmittedOK",
>> +     "aFramesReceivedOK",
>> +     "aFramesCheckSequenceErro
>
> nit: should be const char

Ok, will address.

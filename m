From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2a RESEND 2/2] of_mdio: Allow the DT to specify the phy
 ID and avoid autoprobing
Date: Thu, 20 Mar 2014 02:20:11 +0300
Message-ID: <532A262B.803@cogentembedded.com>
References: <1394658311-17769-1-git-send-email-jgunthorpe@obsidianresearch.com> <1394658311-17769-2-git-send-email-jgunthorpe@obsidianresearch.com> <CAL_Jsq+qdbiwXErkZv1zZ9rphYY9NP6zHmmjw313tMvGeSTODg@mail.gmail.com> <20140319221404.GA1154@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140319221404.GA1154@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 03/20/2014 01:14 AM, Jason Gunthorpe wrote:

>>     The preferred multi-line comment style is:

>> /*
>>   * bla
>>   * bla
>>   */

> Sergei, the entire file use the 'net' multi-line commenting style, and
> I have maintined that consistency with the new code.

    No, you haven't followed the networking style. It is:

/* bla
  * bla
  */

while your comment used:

/* bla
  * bla */

> v3 on its way.

> Regards,
> Jason

WBR, Sergei

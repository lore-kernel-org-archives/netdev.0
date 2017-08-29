From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: fdb add and delete
	tracepoints
Date: Tue, 29 Aug 2017 06:49:50 -0700
Message-ID: <CAJieiUgGU8h5On7NT=bp4AVJn_txP0UBXBHaSF=8SL1yjkA=7Q@mail.gmail.com>
References: <1503980568-35240-1-git-send-email-roopa@cumulusnetworks.com>
	<20170829133648.GF22093@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170829133648.GF22093@lunn.ch>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 6:36 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Aug 28, 2017 at 09:22:48PM -0700, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> A few useful tracepoints to trace bridge forwarding
>> database updates.
>
> Hi Roopa
>
> Once accepted, it would be nice to add mdb tracepoints as well. I
> expect the implementation would be very similar.
>

yes, sounds great. will do.

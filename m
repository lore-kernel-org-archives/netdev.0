From: sl reddy <slreddyforneobux@gmail.com>
Subject: Re: Wifi basics documents
Date: Fri, 8 Feb 2013 16:07:33 +0530
Message-ID: <CAGmqTTTLXhKzoS8U5T5HwVmvgnM+ToADoOdfXUF3DFtEUTNPNQ@mail.gmail.com>
References: <CAHT=_ri0JBrbPfWJrzjYR4eNDDW9ygMkJSDU4vJXEfh_STLK9g@mail.gmail.com>
	<5114B881.9000100@broadcom.com>
	<CAGmqTTSovcse3k4kv5o=+K6adAb672O5nJ=nXfZmc=d36gMSJw@mail.gmail.com>
	<5114D178.10007@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3205397647244920665=="
Cc: brcm80211-dev-list@broadcom.com, Onteddu Slreddy <slreddy88@gmail.com>,
	e1000-devel@lists.sourceforge.net, netdev <netdev@vger.kernel.org>,
	devicetree-discuss <devicetree-discuss@lists.ozlabs.org>,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-can@vger.kernel.org,
	wil6210@qca.qualcomm.com, ath9k-devel@lists.ath9k.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5114D178.10007@broadcom.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============3205397647244920665==
Content-Type: multipart/alternative; boundary=20cf307d00ccab41d804d5342553

--20cf307d00ccab41d804d5342553
Content-Type: text/plain; charset=ISO-8859-1

Thank you

I will start from here

Thanks & Regards

O S L Reddy
slreddy88@gmail.com


On Fri, Feb 8, 2013 at 3:50 PM, Arend van Spriel <arend@broadcom.com> wrote:

> On 02/08/2013 10:53 AM, sl reddy wrote:
> > any successions will be helpful for me
>
> My *suggestion* would be:
>
> http://wireless.kernel.org/en/developers/Documentation
>
> For what it is worth, below is some terrible ascii art.
>
> Gr. AvS
>
> Fullmac model:
>
>                  user-space (libnl)
>                   |
> +----------+      v
> | cfg80211 |------o nl80211 api
> +----------+
>      ^
>      |
>      v
> +----------+
> | fullmac  |------o netdev
> | driver   |
> +----------+
>
> Softmac model:
>
>                  user-space (libnl)
>                   |
> +----------+      v
> | cfg80211 |------o nl80211 api
> +----------+
>      ^
>      |
>      v
> +----------+
> | mac80211 |------o netdev
> +----------+
>      ^
>      |
>      v
> +----------+
> | softmac  |
> | driver   |
> +----------+
>
>
>

--20cf307d00ccab41d804d5342553--


--===============3205397647244920665==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Free Next-Gen Firewall Hardware Offer
Buy your Sophos next-gen firewall before the end March 2013 
and get the hardware for free! Learn more.
http://p.sf.net/sfu/sophos-d2d-feb
--===============3205397647244920665==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3205397647244920665==--

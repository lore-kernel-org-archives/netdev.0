From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: [PATCH v3]net:8021q:vlan.c Fix pr_info to just give the vlan
 fullname and version.
Date: Thu, 26 May 2011 13:14:21 -0700
Message-ID: <4DDEB49D.1070003@gmail.com>
References: <1306219428-11528-1-git-send-email-justinmattock@gmail.com> <20110526.145601.735416831290933990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com, greearb@candelatech.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110526.145601.735416831290933990.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2011 11:56 AM, David Miller wrote:
> From: "Justin P. Mattock"<justinmattock@gmail.com>
> Date: Mon, 23 May 2011 23:43:48 -0700
>
>> The below patch removes vlan_buggyright and vlan_copyright from vlan_proto_init,
>> so that it prints out just the fullname of vlan and the version number.
>>
>> before:
>>
>> [   30.438203] 802.1Q VLAN Support v1.8 Ben Greear<greearb@candelatech.com>
>> [   30.441542] All bugs added by David S. Miller<davem@redhat.com>
>>
>> after:
>>
>> [   31.513910] 802.1Q VLAN Support v1.8
>>
>> Signed-off-by: Justin P. Mattock<justinmattock@gmail.com>
>
> Applied, thanks Justin.
>

cool..

Justin P. Mattock

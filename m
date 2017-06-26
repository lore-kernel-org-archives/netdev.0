From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] batman-adv: fix spelling mistake
 "ourselve" -> "ourself"
Date: Mon, 26 Jun 2017 13:02:44 +0300
Message-ID: <fdaf388e-c2a4-bf3e-4b7e-a1169c72d9e4@cogentembedded.com>
References: <20170625215607.30401-1-colin.king@canonical.com>
 <ade9a7c5-6956-d614-afcc-5476070d025e@cogentembedded.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>,
 Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>, Antonio Quartulli <a@unstable.cc>,
 "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <ade9a7c5-6956-d614-afcc-5476070d025e-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 6/26/2017 1:01 PM, Sergei Shtylyov wrote:

>> From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>>
>> Trivial fix to spelling mistake in batadv_dbg debug message
>>
>> Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>>   net/batman-adv/bat_v_ogm.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
>> index 1e3dc374bfde..d6dbf67acbb5 100644
>> --- a/net/batman-adv/bat_v_ogm.c
>> +++ b/net/batman-adv/bat_v_ogm.c
>> @@ -200,7 +200,7 @@ static void batadv_v_ogm_send(struct work_struct *work)
>>                   type = "unknown";
>>               }
>> -            batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "OGM2 from ourselve on 
>> %s surpressed: %s\n",
>> +            batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "OGM2 from ourself on 
>> %s surpressed: %s\n",
> 
>     I think proper English is "ourselves"...

    Sorry. "ourself" also seems valid. :-)

> [...]

MBR, Sergei

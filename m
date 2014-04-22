From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH][RFC] bridge: mark packets sent to any local
 mac address as PACKET_HOST
Date: Tue, 22 Apr 2014 22:01:49 +0400
Message-ID: <5356AE8D.3070405@cogentembedded.com>
References: <1398189018.19788.2.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, bridge@lists.linux-foundation.org
To: mbizon@freebox.fr, Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1398189018.19788.2.camel@sakura.staff.proxad.net>
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

Hello.

On 04/22/2014 09:50 PM, Maxime Bizon wrote:

> The bridge code only set PACKET_HOST on packets sent to the bridge mac
> address, packets sent to other local mac addresses are sent to upper
> layer, but ignored because they are marked as PACKET_OTHERHOST.

    You forgot to sign off.

WBR, Sergei

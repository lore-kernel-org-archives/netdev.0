From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Multicast snooping fixes and suggestions
Date: Wed, 23 Feb 2011 21:57:32 -0800
Message-ID: <89132767-587d-4186-8eac-9692bed59a44@email.android.com>
References: <1297811961-19249-1-git-send-email-linus.luessing@web.de>
	<4D65CD81.4070203@zytor.com>
	<20110224040412.GA25488@gondor.apana.org.au>
	<4D65E2B4.1010501@zytor.com>
	<20110224054232.GA26064@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6501571822268192522=="
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org,
        =?ISO-8859-1?Q?Linus_L=FCssing?= <linus.luessing@web.de>,
        "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20110224054232.GA26064@gondor.apana.org.au>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Mime-version: 1.0
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--===============6501571822268192522==
Content-Type: multipart/alternative; boundary="----2AY3YV7PJ80115PU715DK692EWXJ9V"

------2AY3YV7PJ80115PU715DK692EWXJ9V
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit

Ok, so stupid question... how do hardware switches deal with this? It would seem to me that if everyone behind say a Cisco switch had these kind of issues they would have limited appeal...
-- 
Sent from my mobile phone. Please pardon any lack of formatting.

Herbert Xu <herbert@gondor.hengli.com.au> wrote:

On Wed, Feb 23, 2011 at 08:46:44PM -0800, H. Peter Anvin wrote: > > I have disabled STP on the bridge; it doesn't change the behavior. Once you have disabled STP, you can set the forward delay to 0 which should do the trick. Cheers, -- Email: Herbert Xu <herbert@gondor.apana.org.au> Home Page: http://gondor.apana.org.au/~herbert/ PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt 


------2AY3YV7PJ80115PU715DK692EWXJ9V
Content-Type: text/html;
 charset=utf-8
Content-Transfer-Encoding: 8bit

<html><head></head><body>Ok, so stupid question... how do hardware switches deal with this?  It would seem to me that if everyone behind say a Cisco switch had these kind of issues they would have limited appeal...<br>
-- <br>
Sent from my mobile phone.  Please pardon any lack of formatting.<br><br><div class="gmail_quote">Herbert Xu &lt;herbert@gondor.hengli.com.au&gt; wrote:<blockquote class="gmail_quote" style="margin: 0pt 0pt 0pt 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
<div style="white-space: pre-wrap; word-wrap:break-word; ">On Wed, Feb 23, 2011 at 08:46:44PM -0800, H. Peter Anvin wrote:
&gt;
&gt; I have disabled STP on the bridge; it doesn't change the behavior.

Once you have disabled STP, you can set the forward delay to 0 which should do the trick.

Cheers,
-- 
Email: Herbert Xu &lt;herbert@gondor.apana.org.au&gt;
Home Page: <a href="http://gondor.apana.org.au/~herbert">http://gondor.apana.org.au/~herbert</a>/
PGP Key: <a href="http://gondor.apana.org.au/~herbert/pubkey.txt">http://gondor.apana.org.au/~herbert/pubkey.txt</a>
</div></blockquote></div></body></html>
------2AY3YV7PJ80115PU715DK692EWXJ9V--


--===============6501571822268192522==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.linux-foundation.org
https://lists.linux-foundation.org/mailman/listinfo/bridge
--===============6501571822268192522==--

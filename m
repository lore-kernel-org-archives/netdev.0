From: Wilfried Weissmann <Wilfried.Weissmann@gmx.at>
Subject: Re: [Ipsec-tools-devel] more phase 2 reinitiation problems
Date: Sun, 20 Mar 2005 15:06:54 +0100
Message-ID: <423D837E.4040203@gmx.at>
References: <42334B29.2080504@gmx.at> <Pine.LNX.4.62.0503181523510.4403@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com
To: Krzysztof Oledzki <olel@ans.pl>
In-Reply-To: <Pine.LNX.4.62.0503181523510.4403@bizon.gios.gov.pl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Krzysztof Oledzki wrote:
> Please giva a try try the 2.6.12-rc1 kernel. I have just upgraded my 
> system to this kernel and it seems that IPSec is able to survive first 
> rekeying. Unfortunately only a first one - after a while (just before 
> removing old expired keys) one of newly generated keys get removed and 
> new traffic racoon generates two news keys. OK, it is _much_ better but 
> still... not perfect.

Hi,

I have not got time to try 2.6.12-rc1 yet but kernel 2.6.11.5 with 
ipsec-tools 0.3.3 works fine.

Bye,
Wilfried

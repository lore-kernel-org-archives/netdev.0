From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH V3 net-next] can-raw: add msg_flags to distinguish local
	traffic
Date: Tue, 19 Oct 2010 13:16:08 +0200
Message-ID: <4CBD7DF8.4040204@grandegger.com>
References: <20101019090247.GB334@e-circ.dyndns.org>	<201010191113.46999.alexander.stein@systec-electronic.com>	<20101019095703.GA436@e-circ.dyndns.org>
	<201010191228.10914.alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
To: Alexander Stein <alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <201010191228.10914.alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/19/2010 12:28 PM, Alexander Stein wrote:
> On Tuesday 19 October 2010, 11:57:03 Kurt Van Dijck wrote:
>> On Tue, Oct 19, 2010 at 11:12:56AM +0200, Alexander Stein wrote:
>>> You mixed tabs and spaces at MSG_CONFIRM entry. Dunno if that was
>>> intended.
>>
>> That was not intended.
>> Is that a problem (I never studied the code style wrt. Documentation)?
> 
> Dunno if this is a problem, I just stumbled over it.

Well, I think it's not worth an extra patch but should be fixed when the
files need to be touched anyway (for other reasons/fixes).

Just my .02 euro.

Wolfgang.

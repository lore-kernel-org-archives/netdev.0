From: Marius Kotsbak <marius.kotsbak@gmail.com>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 11 Jun 2011 23:57:53 +0200
Message-ID: <4DF3E4E1.2070309@gmail.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com> <20110610235557.GA23443@kroah.com> <4DF2B5E4.8070303@gmail.com> <20110611200625.GB14582@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, "Marius B. Kotsbak" <marius@kotsbak.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36744 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab1FKV55 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 17:57:57 -0400
In-Reply-To: <20110611200625.GB14582@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11. juni 2011 22:06, Greg KH wrote:
>>>> > >> + * This program is distributed in the hope that it will be useful,
>>>> > >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>>> > >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
>>>> > >> + * GNU General Public License for more details.
>>>> > >> + *
>>>> > >> + * You should have received a copy of the GNU General Public License
>>>> > >> + * along with this program; if not, write to the Free Software
>>>> > >> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
>>> > > These two paragraphs are not needed, and unless you want to track the
>>> > > FSF's office changes for the next 40+ years, I'd really suggest not
>>> > > putting it in there at all.
>>> > >
>> > 
>> > Same here, I have reused what I found in other modules. Do you have an
>> > example of a module with the recommended header?
> Just take out these two paragraphs and you should be fine, and be sure
> that you really mean "any later" for your license and that you didn't
> copy any code from a non "any later" file.
>

Japp, that is fine for me. Fixed the other stuff and sent updated patch
now. How is the possibility of getting a stable backported version of
this one accepted (to Ubuntu LTS/Natty kernel versions)?

--
Marius



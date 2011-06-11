From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net/usb: Add Samsung Kalmia driver for Samsung GT-B3730
Date: Sat, 11 Jun 2011 15:40:12 -0700
Message-ID: <20110611224011.GA16951@kroah.com>
References: <1307748870-12950-1-git-send-email-marius@kotsbak.com>
 <20110610235557.GA23443@kroah.com>
 <4DF2B5E4.8070303@gmail.com>
 <20110611200625.GB14582@kroah.com>
 <4DF3E4E1.2070309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: Marius Kotsbak <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4DF3E4E1.2070309-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 11, 2011 at 11:57:53PM +0200, Marius Kotsbak wrote:
> On 11. juni 2011 22:06, Greg KH wrote:
> >>>> > >> + * This program is distributed in the hope that it will be useful,
> >>>> > >> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> >>>> > >> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
> >>>> > >> + * GNU General Public License for more details.
> >>>> > >> + *
> >>>> > >> + * You should have received a copy of the GNU General Public License
> >>>> > >> + * along with this program; if not, write to the Free Software
> >>>> > >> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
> >>> > > These two paragraphs are not needed, and unless you want to track the
> >>> > > FSF's office changes for the next 40+ years, I'd really suggest not
> >>> > > putting it in there at all.
> >>> > >
> >> > 
> >> > Same here, I have reused what I found in other modules. Do you have an
> >> > example of a module with the recommended header?
> > Just take out these two paragraphs and you should be fine, and be sure
> > that you really mean "any later" for your license and that you didn't
> > copy any code from a non "any later" file.
> >
> 
> Japp, that is fine for me. Fixed the other stuff and sent updated patch
> now. How is the possibility of getting a stable backported version of
> this one accepted (to Ubuntu LTS/Natty kernel versions)?

Talk to the Ubuntu developers, they are the ones in charge of that.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
